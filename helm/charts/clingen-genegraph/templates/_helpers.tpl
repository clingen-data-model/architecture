{{/*
genegraph chart helpers
*/}}
{{- define "clingen-genegraph.labels" -}}
{{ include "clingen-genegraph.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
helm.sh/chart: {{ .Chart.Name }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "clingen-genegraph.selectorLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}



{{/*genegraph redis labels*/}}
{{- define "genegraph-redis.labels" -}}
{{ include "genegraph-redis.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}
{{- end }}

{{- define "genegraph-redis.selectorLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
