
set -x

if [[ -z $1 ]]; then echo please give the agrument for user; exit 1; fi

USER=$1
PROJECT=${USER}_dev

password=$(echo $RANDOM | sha1sum | head -c 16)

(openstack user show $USER && openstack user set --password $password $USER) || openstack user create --password $password $USER
openstack project show $PROJECT || openstack project create $PROJECT

openstack role add --user $USER --project $PROJECT load-balancer_observer
openstack role add --user $USER --project $PROJECT member
openstack role add --user $USER --project $PROJECT load-balancer_member
openstack role add --user $USER --project $PROJECT heat_stack_user

cat <<EOF
------

user: $USER
password: $password

$(openstack endpoint list -f value -c URL | grep -o http.*: | sort | uniq | head -n 1 | xargs -I% echo %9999)

EOF
