{{- define "clingen-genegraph.updateStrategy" -}}
type: RollingUpdate
rollingUpdate:
  maxSurge: 50%
  maxUnavailable: 50%
{{- end }}
