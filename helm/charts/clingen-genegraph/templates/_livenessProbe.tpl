{{- define "clingen-genegraph.livenessProbe" -}}
livenessProbe:
  periodSeconds: 30
  successThreshold: 1
  httpGet:
    path: /live
    port: genegraph-port
{{- end }}
