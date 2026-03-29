{{/*
Expand the name of the chart.
*/}}
{{- define "music-assistant-alexa-skill.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "music-assistant-alexa-skill.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart label.
*/}}
{{- define "music-assistant-alexa-skill.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "music-assistant-alexa-skill.labels" -}}
helm.sh/chart: {{ include "music-assistant-alexa-skill.chart" . }}
{{ include "music-assistant-alexa-skill.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "music-assistant-alexa-skill.selectorLabels" -}}
app.kubernetes.io/name: {{ include "music-assistant-alexa-skill.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "music-assistant-alexa-skill.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "music-assistant-alexa-skill.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the ConfigMap to use.
Returns existingConfigMap if set, otherwise the chart-managed ConfigMap name.
*/}}
{{- define "music-assistant-alexa-skill.configMapName" -}}
{{- if .Values.existingConfigMap }}
{{- .Values.existingConfigMap }}
{{- else }}
{{- include "music-assistant-alexa-skill.fullname" . }}
{{- end }}
{{- end }}

{{/*
Name of the Secret to use.
Returns existingSecret if set, otherwise the chart-managed Secret name.
*/}}
{{- define "music-assistant-alexa-skill.secretName" -}}
{{- if .Values.existingSecret }}
{{- .Values.existingSecret }}
{{- else }}
{{- include "music-assistant-alexa-skill.fullname" . }}
{{- end }}
{{- end }}

{{/*
Name of the PVC to use.
Returns existingClaim if set, otherwise the chart-managed PVC name.
*/}}
{{- define "music-assistant-alexa-skill.pvcName" -}}
{{- if .Values.persistence.existingClaim }}
{{- .Values.persistence.existingClaim }}
{{- else }}
{{- include "music-assistant-alexa-skill.fullname" . }}
{{- end }}
{{- end }}
