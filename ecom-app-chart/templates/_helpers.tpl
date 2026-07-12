{{- define "ecom-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ecom-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if contains (include "ecom-app.name" .) .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "ecom-app.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "ecom-app.labels" -}}
app.kubernetes.io/name: {{ include "ecom-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end }}

{{- define "ecom-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ecom-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "ecom-app.secretName" -}}
{{- if .Values.secret.create }}
{{- include "ecom-app.fullname" . }}
{{- else }}
{{- required "secret.existingSecret is required when secret.create is false" .Values.secret.existingSecret }}
{{- end }}
{{- end }}
