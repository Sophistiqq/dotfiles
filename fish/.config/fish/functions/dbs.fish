function dbs --wraps='sudo systemctl start mariadb' --description 'alias dbs sudo systemctl start mariadb'
  sudo systemctl start mariadb $argv
        
end
