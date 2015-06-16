class API
  attr_reader :connection, :cert_path

  def initialize(host, cert_path = nil)
    @cert_path = cert_path
    @connection = Faraday.new host, :ssl => {
      :client_key  => client_key(cert_path),
      :client_cert => client_cert(cert_path),
      :verify      => false,
      :version     => "TLSv1"
    }
  end

  def client_key(path)
    OpenSSL::PKey::RSA.new(File.read path) unless cert_path.nil?
  end

  def client_cert(path)
    OpenSSL::X509::Certificate.new(File.read path) unless cert_path.nil?
  end

  def post(payload)
    connection.headers[:content_type] = "application/json"
    connection.post "/write", payload
  end
end
