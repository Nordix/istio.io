#!/bin/bash
# shellcheck disable=SC2034,SC2153,SC2155,SC2164

# Copyright Istio Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

####################################################################################################
# WARNING: THIS IS AN AUTO-GENERATED FILE, DO NOT EDIT. PLEASE MODIFY THE ORIGINAL MARKDOWN FILE:
#          docs/ambient/getting-started/enforce-auth-policies/index.md
####################################################################################################

snip_deploy_l4_policy() {
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: productpage-ztunnel
  namespace: default
spec:
  selector:
    matchLabels:
      app: productpage
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/default/sa/bookinfo-gateway-istio
EOF
}

snip_deploy_curl() {
kubectl apply -f samples/curl/curl.yaml
}

snip_enforce_layer_4_authorization_policy_3() {
kubectl exec deploy/curl -- curl -s "http://productpage:9080/productpage"
}

! IFS=$'\n' read -r -d '' snip_enforce_layer_4_authorization_policy_3_out <<\ENDSNIP
command terminated with exit code 56
ENDSNIP

snip_deploy_waypoint() {
istioctl waypoint apply --enroll-namespace --wait
}

! IFS=$'\n' read -r -d '' snip_deploy_waypoint_out <<\ENDSNIP
✅ waypoint default/waypoint applied
✅ waypoint default/waypoint is ready!
✅ namespace default labeled with "istio.io/use-waypoint: waypoint"
ENDSNIP

snip_enforce_layer_7_authorization_policy_2() {
kubectl get gtw waypoint
}

! IFS=$'\n' read -r -d '' snip_enforce_layer_7_authorization_policy_2_out <<\ENDSNIP
NAME       CLASS            ADDRESS       PROGRAMMED   AGE
waypoint   istio-waypoint   10.96.58.95   True         42s
ENDSNIP

snip_deploy_l7_policy() {
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: productpage-waypoint
  namespace: default
spec:
  targetRefs:
  - kind: Service
    group: ""
    name: productpage
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/default/sa/curl
    to:
    - operation:
        methods: ["GET"]
EOF
}

snip_update_l4_policy() {
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: productpage-ztunnel
  namespace: default
spec:
  selector:
    matchLabels:
      app: productpage
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/default/sa/bookinfo-gateway-istio
        - cluster.local/ns/default/sa/waypoint
EOF
}

snip_enforce_layer_7_authorization_policy_5() {
# This fails with an RBAC error because you're not using a GET operation
kubectl exec deploy/curl -- curl -s "http://productpage:9080/productpage" -X DELETE
}

! IFS=$'\n' read -r -d '' snip_enforce_layer_7_authorization_policy_5_out <<\ENDSNIP
RBAC: access denied
ENDSNIP

snip_enforce_layer_7_authorization_policy_6() {
# This fails with an RBAC error because the identity of the reviews-v1 service is not allowed
kubectl exec deploy/reviews-v1 -- curl -s http://productpage:9080/productpage
}

! IFS=$'\n' read -r -d '' snip_enforce_layer_7_authorization_policy_6_out <<\ENDSNIP
RBAC: access denied
ENDSNIP

snip_enforce_layer_7_authorization_policy_7() {
# This works as you're explicitly allowing GET requests from the curl pod
kubectl exec deploy/curl -- curl -s http://productpage:9080/productpage | grep -o "<title>.*</title>"
}

! IFS=$'\n' read -r -d '' snip_enforce_layer_7_authorization_policy_7_out <<\ENDSNIP
<title>Simple Bookstore App</title>
ENDSNIP
