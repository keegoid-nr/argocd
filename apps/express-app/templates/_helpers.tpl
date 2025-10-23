{{/* vim: set filetype=gotemplate: */}}
{{- define "express-app.chartName" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "express-app.appName" -}}
{{- .Values.appName | default (include "express-app.chartName" .) -}}
{{- end -}}

{{- define "express-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{ .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := include "express-app.appName" . -}}
{{- if contains .Chart.Name .Release.Name }}
{{ .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{ printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "express-app.labels" -}}
helm.sh/chart: {{ printf "%s-%s" (include "express-app.chartName" .) .Chart.Version | quote }}
app.kubernetes.io/name: {{ include "express-app.appName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ if .Values.customLabels }}
{{ toYaml .Values.customLabels }}
{{ end }}
{{- end -}}

{{- define "express-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "express-app.appName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Image name construction (matches original script logic) */}}
{{- define "express-app.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- $repository := .Values.image.repository -}}
{{- if $repository -}}
{{- printf "%s:%s" $repository $tag -}}
{{- else -}}
{{- printf "%s.dkr.ecr.%s.amazonaws.com/%s-%s:%s" (.Values.aws.accountId | toString) .Values.aws.region .Values.clusterName (include "express-app.appName" .) $tag -}}
{{- end -}}
{{- end -}}
