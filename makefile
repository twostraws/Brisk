install:
	@# Flush out any existing Brisk template
	@rm -rf ~/.brisk

	@# Prepare to park our template in the hidden folder
	@mkdir ~/.brisk

	@# Copy our entire template into the hidden folder
	@cp -R . ~/.brisk/Brisk

	@# Place our script creator in a sensible place
	@install brisk.sh /usr/local/bin/brisk

	@# Make it executable, so they can run "brisk fizz"
	@chmod u+x /usr/local/bin/brisk

	@echo "Installation complete!"
	@echo "You can now run \"brisk example\" to make a new script."

uninstall:
	@# Remove any existing Brisk template
	@rm -rf ~/.brisk

	@# Remove our script creator
	@rm -rf /usr/local/bin/brisk

	@echo "Uninstall complete."
