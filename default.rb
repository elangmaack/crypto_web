apt_update 'Update the apt cache daily' do
  frequency 86_400
  action :periodic
end

package 'apache2'

service 'apache2' do
  supports status: true
  action [:enable, :start]
end

template '/var/www/html/index.html' do
  source 'index.html.erb'
end

directory '/var/www/html/cgi-bin' do
  mode 0755
end

template '/var/www/html/cgi-bin/print_all_positions_html.py' do
  source 'print_all_positions_html.erb'
  mode 0755
end

template '/var/www/html/cgi-bin/my_positions.txt' do
  source 'my_positions.erb'
  mode 0755
end

template '/etc/apache2/apache2.conf' do
  source 'apache2.erb'
end

file '/etc/apache2/conf-available/serve-cgi-bin.conf' do
  content '<IfModule mod_alias.c>
	<IfModule mod_cgi.c>
		Define ENABLE_USR_LIB_CGI_BIN
	</IfModule>

	<IfModule mod_cgid.c>
		Define ENABLE_USR_LIB_CGI_BIN
	</IfModule>

	<IfDefine ENABLE_USR_LIB_CGI_BIN>
		ScriptAlias /cgi-bin/ /var/www/html/cgi-bin/
		<Directory "/var/www/html/cgi-bin">
			AllowOverride None
			Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
			Require all granted
			AddHandler cgi-script .py
			AddHandler cgi-script .cgi
			AddHandler wsgi-script .wsgi
		</Directory>
	</IfDefine>
</IfModule>
'
end
