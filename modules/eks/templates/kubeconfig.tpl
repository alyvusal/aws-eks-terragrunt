apiVersion: v1
kind: Config
preferences: {}

clusters:
- cluster:
    server: ${endpoint}
    certificate-authority-data: ${cluster_auth_base64}
  name: ${kubeconfig_name}

contexts:
- context:
    cluster: ${kubeconfig_name}
    user: ${kubeconfig_name}_admin
  name: ${kubeconfig_name}

current-context: ${kubeconfig_name}

users:
- name: ${kubeconfig_name}_admin
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: ${aws_authenticator_command}
      args:
%{~ for i in aws_authenticator_command_args }
        - "${i}"
%{~ endfor ~}
%{ for i in aws_authenticator_additional_args }
        - ${i}
%{~ endfor ~}
%{ if length(aws_authenticator_env_variables) > 0 }
      env:
  %{~ for k, v in aws_authenticator_env_variables ~}
        - name: ${k}
          value: ${v}
  %{~ endfor ~}
%{ endif }
- name: ${kubeconfig_name}_iam
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: ${aws_authenticator_command2}
      args:
%{~ for i in aws_authenticator_command_args2 }
        - "${i}"
%{~ endfor ~}
%{ for i in aws_authenticator_additional_args2 }
        - ${i}
%{~ endfor ~}

      # create role https://github.com/kubernetes-sigs/aws-iam-authenticator#1-create-an-iam-role
      # - "-r"
      # - "arn:aws:iam::<account>:role/KubernetesAdmin"
%{ if length(aws_authenticator_env_variables) > 0 }
      env:
  %{~ for k, v in aws_authenticator_env_variables ~}
        - name: ${k}
          value: ${v}
  %{~ endfor ~}
%{ endif }
