tools = helm helm-docs kubectl siege
$(tools):
	@which $@ > /dev/null

# Acquire the Kiali login token for dashboard.
# Refer to: https://kiali.io/docs/faq/authentication/
.PHONY: get-kiali-login-token
get-kiali-login-token:
	@kubectl -n istio-system create token kiali
