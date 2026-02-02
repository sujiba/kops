# Assign user admin role
```bash
kubectl --kubeconfig ~/.kube/hcloud \
  -n selfhosted exec -it matrix-matrix-authentication-service-85c8556969-fgbzt
  -- mas-cli manage promote-admin <USERNAME>
```