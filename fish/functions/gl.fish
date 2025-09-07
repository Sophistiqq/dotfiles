function gl --wraps='git log --decorate --oneline --graph' --description 'alias gl git log --decorate --oneline --graph'
  git log --decorate --oneline --graph $argv
        
end
