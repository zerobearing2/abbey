# Abbey

## Sample Bash Function I use

  function abbey() {
    if [ "$1" = "help" ]
    then
      echo
      echo "${orange}**** Abbey defaults ****"
      echo " Runs the rails new command, taking up to 3 arguments."
      echo " Does not include Prototype or Test Unit."
      echo " Runs the abbey template."
      echo " ${reset_color}"
      echo " ${bold_blue}rails new \$1 \$2 \$3 -J -T --template=/Users/revans/Development/cw/open_source/abbey/abbey.rb"
      echo
      echo "${green}**** Abbey usage ****"
      echo " abbey application_name -d=mysql -O"
      echo " abbey application_name -d=mysql"
      echo " abbey application_name -O"
      echo " abbey application_name"
      echo " ${reset_color}"
    else
      rails new $1 $2 $3 -J -T --template=/Users/revans/Development/cw/open_source/abbey/abbey.rb
    fi
  }