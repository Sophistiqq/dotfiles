function cdcs --wraps="curl -X GET https://cdcs-backend.onrender.com/clipboard | jq -r '.[].text' | wl-copy " --wraps="curl https://cdcs-backend.onrender.com/clipboard | jq -r '.[].text' | wl-copy " --wraps="curl -s https://cdcs-backend.onrender.com/clipboard | jq -r '.[].text' | wl-copy " --wraps="curl -s https://cdcs-backend.onrender.com/clipboard | jq -r '.[0].text' | wl-copy " --description "alias cdcs curl -s https://cdcs-backend.onrender.com/clipboard | jq -r '.[0].text' | wl-copy "
  curl -s https://cdcs-backend.onrender.com/clipboard | jq -r '.[0].text' | wl-copy  $argv
        
end
