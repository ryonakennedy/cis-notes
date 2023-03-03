.lpstat -p -d
find . -regex '.*\.md' -exec lp -d <printer_name> {} \;