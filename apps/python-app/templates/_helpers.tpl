{{/* vim: set filetype=gotemplate: */}}
{{- define "python-app.chartName" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "python-app.appName" -}}
{{- .Values.appName | default (include "python-app.chartName" .) -}}
{{- end -}}

{{- define "python-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{ .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := include "python-app.appName" . -}}
{{- if contains .Chart.Name .Release.Name }}
{{ .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{ printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "python-app.labels" -}}
helm.sh/chart: {{ printf "%s-%s" (include "python-app.chartName" .) .Chart.Version | quote }}
app.kubernetes.io/name: {{ include "python-app.appName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ if .Values.customLabels }}
{{ toYaml .Values.customLabels }}
{{ end }}
{{- end -}}

{{- define "python-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "python-app.appName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Image name construction (matches original script logic) */}}
{{- define "python-app.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- $repository := .Values.image.repository -}}
{{- if $repository -}}
{{- printf "%s:%s" $repository $tag -}}
{{- else -}}
{{- printf "%s.dkr.ecr.%s.amazonaws.com/%s-%s:%s" (.Values.aws.accountId | toString) .Values.aws.region .Values.clusterName (include "python-app.appName" .) $tag -}}
{{- end -}}
{{- end -}}
