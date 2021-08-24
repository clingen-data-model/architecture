{{/*
Chart labels
*/}}
{{- define "clinvar-combined.chartLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
helm.sh/chart: {{ .Chart.Name }}
{{- end }}

{{- define "clinvar-combined.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
