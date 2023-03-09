{{/*
chart helpers
*/}}
{{- define "clingen-vicc.labels" -}}
{{ include "clingen-vicc.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
helm.sh/chart: {{ .Chart.Name }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "clingen-vicc.selectorLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
