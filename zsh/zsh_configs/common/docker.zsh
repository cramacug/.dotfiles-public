

# DOCKER LOCAL --> dl
alias dlbl='docker build --file Dockerfile --tag $(basename $PWD):dev '
alias dlrit='docker run --rm --name $(basename $PWD) --interactive  --tty $(basename $PWD):dev'
alias drall='docker ps --quiet --all | xargs -I X docker stop X | xargs -I X docker rm X'

# alias dlr='docker run --rm $(basename $PWD):dev pytest'
# alias dlr='docker run --rm --name $(basename $PWD) $(basename $PWD):dev'
# alias dlnr='docker run --rm --network=host $(basename $PWD):dev'
# alias dlnit='docker run --rm --interactive --tty --network=host $(basename $PWD):dev'

# DOCKER COMPOSE
# alias dcud='docker compose --file ./docker-compose.yml up --detach'
# alias dcd='docker compose --file ./docker-compose.yml down --rmi local --volumes --remove-orphans'
# alias dcdra='docker compose --file ./docker-compose.yml down --rmi all --volumes --remove-orphans'
alias dcl='docker compose --file ./docker-compose.yml logs --follow'
alias dex='docker exec --interactive --tty'
# alias dip='docker image prune --force'
# alias dcdri='docker compose --file ./docker-compose.yml down --rmi all'
# alias dcdrv='docker compose --file ./docker-compose.yml down --volumes --remove-orphans'
alias docker_psf='docker ps --format "{{.ID}} -- {{.State}} -- {{.Ports}} -- {{.Names}}"'
alias dcr='docker compose up --detach --force-recreate --no-deps '
# alias dcdidea='find -E ~/IdeaProjects -type file -regex ".*docker-compose.ya?ml" -print0 | xargs -0 -I X docker compose --file X down'
# alias dcdidea='find -E ~/IdeaProjects -type file -regex ".*docker-compose.ya?ml" -print0 | xargs -t -0 -I X docker compose --file X down | echo "------\n" '

# Docker CLI completions (added by Docker Desktop)
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
compinit -u -d "$ZSH_COMPDUMP"

dcd() {
  local file="./docker-compose.yml"

  # If the first argument is not a flag, treat it as the compose file path
  if [[ $# -gt 0 && "$1" != -* ]]; then
    file="$1"
    shift
  fi

  if [[ ! -f "$file" ]]; then
    echo "dcd: compose file not found: $file" >&2
    return 1
  fi

  echo "Tearing down: $file"
  docker compose --file "$file" down --rmi local --volumes --remove-orphans "$@"
}

dcud() {
  local file="./docker-compose.yml"

  # If the first argument is not a flag, treat it as the compose file path
  if [[ $# -gt 0 && "$1" != -* ]]; then
    file="$1"
    shift
  fi

  if [[ ! -f "$file" ]]; then
    echo "dcud: compose file not found: $file" >&2
    return 1
  fi

  echo "Starting: $file"
  docker compose --file "$file" up --detach "$@"
}
