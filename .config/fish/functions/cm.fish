function cm --wraps='sudo systemctl restart change-mac.service' --wraps='sudo systemctl restart set-mac' --description 'alias cm sudo systemctl restart set-mac'
  sudo systemctl restart set-mac $argv
        
end
