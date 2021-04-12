{{/*
Selector labels
*/}}
{{- define "clingen-anyvar.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clingen-anyvar.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
