# List of printer names
lpstat -p -d
# Print all md recursively
find .  -regex '.*\.md' -exec lp -d <printer_name> {} \;