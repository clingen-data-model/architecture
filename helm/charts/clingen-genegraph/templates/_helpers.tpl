{{/* 
genegraph chart helpers
*/}}
{{- define "clingen-genegraph.chartLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
helm.sh/chart: {{ .Chart.Name }}
{{- end }}
