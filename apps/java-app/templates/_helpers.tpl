{{/* vim: set filetype=gotemplate: */}}
{{/* Chart name - typically matches the directory name of the chart */}}
{{- define "java-app.chartName" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/* Application name - this is the name used for resources, derived from values */}}
{{- define "java-app.appName" -}}
{{- .Values.appName | default (include "java-app.chartName" .) -}}
{{- end -}}

{{/* Fully qualified app name for some resource name fields if needed */}}
{{- define "java-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := include "java-app.appName" . -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Common labels */}}
{{- define "java-app.labels" -}}
helm.sh/chart: {{ printf "%s-%s" (include "java-app.chartName" .) .Chart.Version | quote }}
app.kubernetes.io/name: {{ include "java-app.appName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.customLabels }}
{{ toYaml .Values.customLabels }}
{{- end }}
{{- end -}}

{{/* Selector labels - critical for deployments, services, HPA */}}
{{- define "java-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "java-app.appName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Service Account name */}}
{{- define "java-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- .Values.serviceAccount.name | default (printf "%s-sa" (include "java-app.appName" .)) -}}
{{- else -}}
{{- .Values.serviceAccount.name | default "java-app-sa" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate service account name.
- If create is true, return the generated name.
- If create is false but a name is given, return that name.
- Otherwise, return an empty string.
*/}}
{{- define "java-app.getServiceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- include "java-app.serviceAccountName" . -}}
{{- else if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/* Image name construction (matches original script logic) */}}
{{- define "java-app.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- $repository := .Values.image.repository -}}
{{- if $repository -}}
{{- printf "%s:%s" $repository $tag -}}
{{- else -}}
{{- printf "%s.dkr.ecr.%s.amazonaws.com/%s-%s:%s" (.Values.aws.accountId | toString) .Values.aws.region .Values.clusterName (include "java-app.appName" .) $tag -}}
{{- end -}}
{{- end -}}
