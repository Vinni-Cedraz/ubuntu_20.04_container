user=root
user_home=/root

xdg_runtime_owner_uid=$(stat -c %u $XDG_RUNTIME_DIR)

# Check if the owner's UID is 0 (root)
if [ "$xdg_runtime_owner_uid" -eq 0 ]; then
	echo "owner of $XDG_RUNTIME_DIR is root"; 
else
    user=myuser
    user_home=/home/myuser
	echo "owner of $XDG_RUNTIME_DIR is not root"; 
fi

echo $user
echo $user_home
