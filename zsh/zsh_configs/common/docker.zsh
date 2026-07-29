

# DOCKER LOCAL --> dl
alias dlbl='docker build --file Dockerfile --tag $(basename $PWD):dev '
alias dlrit='docker run --rm --name $(basename $PWD) --interactive  --tty $(basename $PWD):dev'
alias drall='docker ps --quiet --all | xargs -I X docker stop X | xargs -I X docker rm X'

# alias dlr='docker run --rm $(basename $PWD):dev pytest'
# alias dlr='docker run --rm --name $(basename $PWD) $(basename $PWD):dev'
# alias dlnr='docker run --rm --network=host $(basename $PWD):dev'
# alias dlnit='docker run --rm --interactive --tty --network=host $(basename $PWD):dev'

# DOCKER COMPOSE
alias dcud='docker compose --file ./docker-compose.yml up --detach'
alias dcd='docker compose --file ./docker-compose.yml down'
alias dcdri='docker compose --file ./docker-compose.yml down --rmi all'
alias dcdrv='docker compose --file ./docker-compose.yml down --volumes --remove-orphans'
alias dcdra='docker compose --file ./docker-compose.yml down --rmi all --volumes --remove-orphans'
# alias docker_psf='docker ps --format "{{.ID}} -- {{.State}} -- {{.Ports}} -- {{.Names}}"'
# alias dcdidea='find -E ~/IdeaProjects -type file -regex ".*docker-compose.ya?ml" -print0 | xargs -0 -I X docker compose --file X down'
# alias dcdidea='find -E ~/IdeaProjects -type file -regex ".*docker-compose.ya?ml" -print0 | xargs -t -0 -I X docker compose --file X down | echo "------\n" '

# Docker CLI completions (added by Docker Desktop)
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
compinit


