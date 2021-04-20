{{- define "clingen-genegraph.podAntiAffinity" -}}
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: kubernetes.io/hostname
      labelSelector:
        matchLabels:
          app: {{ .Release.Name }}
{{- end }}
