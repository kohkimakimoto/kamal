class Kamal::Secrets::Adapters::AwsSecretsManager < Kamal::Secrets::Adapters::Base
  private
    def login(_account)
      nil
    end

    def fetch_secrets(secrets, account:, session:)
      {}.tap do |results|
        JSON.parse(get_from_secrets_manager(secrets, account: account))["SecretValues"].each do |secret|
          secret_name = secret["Name"]
          secret_string = JSON.parse(secret["SecretString"])

          secret_string.each do |key, value|
            results["#{secret_name}/#{key}"] = value
          end
        end
      end
    end

    def get_from_secrets_manager(secrets, account:)
      `aws secretsmanager batch-get-secret-value --secret-id-list #{secrets.map(&:shellescape).join(" ")} --profile #{account.shellescape}`.tap do
        raise RuntimeError, "Could not read #{secret} from AWS Secrets Manager" unless $?.success?
      end
    end

    def check_dependencies!
      raise RuntimeError, "AWS CLI is not installed" unless cli_installed?
    end

    def cli_installed?
      `aws --version 2> /dev/null`
      $?.success?
    end
end
