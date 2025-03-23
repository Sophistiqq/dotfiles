function cm --wraps='sudo systemctl restart change-mac.service' --description 'alias cm sudo systemctl restart change-mac.service'
  sudo systemctl restart change-mac.service $argv
        
end
