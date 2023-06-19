{{- define "toAlbAnnotations" -}}
  {{- if . -}}

    {{- /* Lookup Tables */ -}}
    {{- $specialEnums := dict
      "ip-address-type"                     (list "ipv4" "dualstack")
      "scheme"                              (list "internal" "internet-facing")
      "backend-protocol"                    (list "HTTP" "HTTPS")
      "healthcheck-port"                    (list "traffic-port" "integer")
      "healthcheck-protocol"                (list "HTTP" "HTTPS")
      "auth-type"                           (list "none" "oidc" "cognito")
      "auth-on-unauthenticated-request"     (list "authenticate" "allow" "deny")
    -}}
    {{- $specialJsons := list
      "listen-ports"
      "auth-idp-cognito"
      "auth-idp-oidc"
    -}}
    {{- $stringListSeparators := dict
      "auth-scope"                          " "
    -}}

    {{- range $k, $v := . -}}
      {{- if empty $v | not -}}

        {{- /* TODO: Strip annotation prefix if exists in values */ -}}

        {{- /* Declarations */ -}}
        {{- $annotationKey := printf "alb.ingress.kubernetes.io/%s" $k | quote -}}
        {{- $annotationValue := "" -}}

        {{- /* Special values that need to be treated as json strings */ -}}
        {{- if or
          ($specialJsons | has $k)
          ($k | hasPrefix "actions.")
          ($k | hasPrefix "conditions.")
        -}}
          {{- $annotationValue = $v | toJson | quote -}}

        {{- /* Special keys with enum values & validation */ -}}
        {{- else if keys $specialEnums | has $k -}}

          {{- /* Edge case for healthcheck-port, can either be the string 'traffic-port' or an integer */ -}}
          {{- /* TODO: If integer, check the value for being in-between the valid port ranges */ -}}
          {{- if $k | eq "healthcheck-port" -}}
            {{- if or
              ($v | eq "traffic-port")
              ($v | kindIs "int")
            -}}
              {{- $annotationValue = $v | quote -}}
            {{- else -}}
              {{- printf "healthcheck-port expected 'traffic-port' or valid int, got %s" $v | fail -}}
            {{- end -}}

          {{- /* Other types can be generically checked */ -}}
          {{- else -}}
            {{- if get $specialEnums $k | has $v | not -}}
              {{- printf "key '%s' expected '%s' got %s"
                $k
                (join "|" (get $specialEnums $k))
                | fail
              -}}
            {{- else -}}
              {{- $annotationValue = $v | quote -}}
            {{- end -}}
          {{- end -}}

        {{- /* StringList types */ -}}
        {{- else if kindIs "slice" $v -}}
          {{- if $k | hasKey $stringListSeparators -}}
            {{- $annotationValue = join (get $stringListSeparators $k) $v | quote -}}
          {{- else -}}
            {{- /* Default list of strings separator is comma */ -}}
            {{- $annotationValue = join "," $v | quote -}}
          {{- end -}}

        {{- /* StringMap types */ -}}
        {{- else if kindIs "map" $v -}}
          {{- $stringMapEntries := list -}}
          {{- range $vk, $vv := $v -}}
            {{- $stringMapEntries = printf "%s=%s" $vk $vv | append $stringMapEntries -}}
          {{- end -}}
          {{- $annotationValue = join "," $stringMapEntries | quote -}}

        {{- /* Straight-forward string and int values */ -}}
        {{- else if kindIs "string" $v -}}
          {{- $annotationValue = $v | quote -}}
        {{- else if kindIs "int" $v -}}
          {{- $annotationValue = $v | quote -}}

        {{- /* Everything else, risky */ -}}
        {{- else -}}
          {{- $annotationValue = $v -}}

        {{- end -}}

        {{- /* Finally create the alb annotation */ -}}
        {{- printf "%s: %s" $annotationKey $annotationValue | nindent 4 -}}

      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}