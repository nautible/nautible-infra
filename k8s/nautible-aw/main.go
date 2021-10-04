package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"io/ioutil"
	"encoding/json"
	"strings"
	"log"
	"regexp"
	"strconv"	
	"k8s.io/api/admission/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/serializer"
	corev1 "k8s.io/api/core/v1"
)

// config struct
type config struct {
	certFile  string
	keyFile   string
	hostRegex string
	addr      string
}

// patchOperation struct
type patchOperation struct {
	Op    string      `json:"op"`
	Path  string      `json:"path"`
	Value interface{} `json:"value,omitempty"`
}

// var
var (
	runtimeScheme = runtime.NewScheme()
	codecs        = serializer.NewCodecFactory(runtimeScheme)
	deserializer  = codecs.UniversalDeserializer()
	exludesNamespaces = strings.Split(os.Getenv("TARGET_RULE_EXCLUDE_NAMESPACES"),",")
	includesPodNames = strings.Split(os.Getenv("TARGET_RULE_INCLUDE_POD_NAMES"),",")
)

// init flag
func initFlags() *config {
	cfg := &config{}
	fl := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	fl.StringVar(&cfg.certFile, "tls-cert-file", "", "TLS certificate file")
	fl.StringVar(&cfg.keyFile, "tls-key-file", "", "TLS key file")
	fl.StringVar(&cfg.addr, "listen-addr", ":8080", "The address to start the server")

	fl.Parse(os.Args[1:])

	return cfg
}

// http request handler
func mutateRequestHandler(w http.ResponseWriter, r *http.Request) {
	infoLog("mutating handler called")

	// read request
	pod, ar , err := mutateReadRequest(w, r)
	if err {
		return
	}

	// create patch
	patchBytes, err := createPatch(w, pod)
	if err {
		return
	}

	// write response
	mutateWriteResponse(w, ar, patchBytes)
}

// read http request
func mutateReadRequest(w http.ResponseWriter, r *http.Request)(*corev1.Pod, *v1.AdmissionReview, bool){
	// verify request body
	var body []byte
	if r.Body != nil {
		if data, err := ioutil.ReadAll(r.Body); err == nil {
			body = data
		}
	}
	if len(body) == 0 {
		http.Error(w, "empty body", http.StatusBadRequest)
		return nil, nil, true
	}

	// verify the content type is accurate
	contentType := r.Header.Get("Content-Type")
	if contentType != "application/json" {
		errorLog("Content-Type=%s, expect application/json", contentType)
		http.Error(w, "invalid Content-Type, expect `application/json`", http.StatusUnsupportedMediaType)
		return nil,nil, true
	}

	// deserializer request body
	ar := v1.AdmissionReview{}
	if _, _, err := deserializer.Decode(body, nil, &ar); err != nil {
		errorLog("Can't decode body: %v", err)
		http.Error(w, "Can't decode body", http.StatusBadRequest)
		return nil,nil, true
	}

	// Unmarshal request to pod
	req := ar.Request
	var pod corev1.Pod
	if err := json.Unmarshal(req.Object.Raw, &pod); err != nil {
		errorLog("Could not unmarshal raw object: %v", err)
		http.Error(w, "Could not unmarshal raw object", http.StatusBadRequest)
		return nil,nil, true
	}
	return &pod, &ar, false
}

// write http request
func mutateWriteResponse(w http.ResponseWriter,ar *v1.AdmissionReview, patchBytes []byte){
	// create admissionResponse
	var admissionResponse *v1.AdmissionResponse
	admissionResponse =  &v1.AdmissionResponse{
		Allowed: true,
		Patch:   patchBytes,
		PatchType: func() *v1.PatchType {
			pt := v1.PatchTypeJSONPatch
			return &pt
		}(),
	}

	admissionReview := v1.AdmissionReview{}
	if admissionResponse != nil {
		admissionReview.Response = admissionResponse
		if ar.Request != nil {
			admissionReview.Response.UID = ar.Request.UID
		}
	}

	// Marshal responce
	resp, err := json.Marshal(admissionReview)

	if err != nil {
		errorLog("Can't encode response: %v", err)
		http.Error(w, fmt.Sprintf("could not encode response: %v", err), http.StatusInternalServerError)
	}

	// write responce
	if _, err := w.Write(resp); err != nil {
		errorLog("Can't write response: %v", err)
		http.Error(w, fmt.Sprintf("could not write response: %v", err), http.StatusInternalServerError)
	}
}

// create mutation patch for resoures
func createPatch(w http.ResponseWriter,pod *corev1.Pod) ([]byte, bool) {	
	var patch []patchOperation
	if(isTargetPod(pod)){
		infoLog(getPodName(pod) + " is patch target.")
		patch = append(patch, createEnvironmentPatch(pod)...)
	}else{
		infoLog(getPodName(pod) + " is not patch target.")
	}
	patchBytes, err := json.Marshal(patch)
	if err != nil {
		errorLog("could not marshal patch: %v", err)
		http.Error(w, fmt.Sprintf("could not marshal patch: %v: %v", err), http.StatusInternalServerError)
		return nil, true
	}
	return patchBytes, false
}

// create environment patch
func createEnvironmentPatch(pod *corev1.Pod) (patch []patchOperation) {
	var value interface{}
	var path string
	for i, con := range pod.Spec.Containers {
		firstEnv := len(con.Env) == 0

		for _, osenv := range os.Environ() {
			// not shara target
			if !strings.HasPrefix(osenv,"SHARE_"){
				continue
			}
			slice := strings.Split(osenv,"=")
			path = "/spec/containers/"+ strconv.Itoa(i) +"/env"
			if firstEnv {
				firstEnv = false
				value = []corev1.EnvVar{
					corev1.EnvVar{
						Name: slice[0][6:len(slice[0])],
						Value: slice[1],
					},
				}
			} else {
				path = path +"/-"
				value = corev1.EnvVar{
					Name: slice[0][6:len(slice[0])],
					Value: slice[1],
				}
			}
			patch = append(patch, patchOperation{
				Op:    "add",
				Path:  path,
				Value: value,
			})
		}
	}
	return patch
}

// judge pod is target or not
func isTargetPod(pod *corev1.Pod) (bool){

	podName := getPodName(pod)

	for _,n := range includesPodNames {
		r := regexp.MustCompile(n)
		if r.MatchString(podName) {
			infoLog("include pod name is matched")
			return true
		}
	}

	for _,n := range exludesNamespaces {
		r := regexp.MustCompile(n)
		if r.MatchString(pod.ObjectMeta.Namespace) {
			infoLog("exclude namespace is matched")
			return false
		}
	}
	return true
}

// get pod name 
func getPodName(pod *corev1.Pod)(string){
	podName := pod.Name
	if podName == "" {
		podName = pod.GenerateName
	}
	return podName
}

// main
func main() {

	cfg := initFlags()

	infoLog("start nautible-admission-controller")
	http.HandleFunc("/mutate", mutateRequestHandler) 
	err := http.ListenAndServeTLS(cfg.addr, cfg.certFile, cfg.keyFile,nil)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error serving webhook: %s", err)
		os.Exit(1)
	}
	infoLog("end nautible-admission-controller")
}

// log api with prefix
func logWithPrefix(prefix, format string, args ...interface{}) {
	format = fmt.Sprintf("%s %s", prefix, format)
	log.Printf(format, args...)
}

// info log
func infoLog(format string, args ...interface{}) {
	logWithPrefix("[INFO]", format, args...)
}

// error log
func errorLog(format string, args ...interface{}) {
	logWithPrefix("[ERROR]", format, args...)
}
