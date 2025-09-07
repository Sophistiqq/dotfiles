function lst --wraps='eza -l --sort modified --reverse' --description 'alias lst eza -l --sort modified --reverse'
  eza -l --sort modified --reverse $argv
        
end
