{{/*
Selector labels
*/}}
{{- define "clingen-anyvar.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clingen-anyvar.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Chart labels
*/}}
{{- define "clingen-anyvar.chartLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
helm.sh/chart: {{ .Chart.Name }}
{{- end }}
