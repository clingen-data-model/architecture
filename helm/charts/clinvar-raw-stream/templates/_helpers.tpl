{{/*
Chart labels
*/}}
{{- define "clinvar-raw.chartLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
helm.sh/chart: {{ .Chart.Name }}
{{- end }}

{{- define "clinvar-raw.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
