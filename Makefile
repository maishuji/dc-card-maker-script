.PHONY: run-dst run-delete run-sd install-genisoimage check-deps

run-dst:
	@echo "Running tests..."
	./dc-card-maker.sh ./listgames.txt ./src_dir ./dst_dir
	
run-delete:
	sudo rm -rf /media/daoliangshu/911E-9389/

run-sd:
	@echo "Running SD card tests..."
	./dc-card-maker.sh ./listgames.txt ./src_dir /media/daoliangshu/911E-9389/

install-genisoimage:
	@echo "Installing genisoimage from sources..."
	./install-genisoimage.sh

check-deps:
	@echo "Checking required dependencies..."
	@(command -v genisoimage >/dev/null 2>&1 || command -v mkisofs >/dev/null 2>&1) && echo "✓ genisoimage/mkisofs" || echo "✗ genisoimage/mkisofs (run 'make install-genisoimage')"
	@command -v hexdump >/dev/null 2>&1 && echo "✓ hexdump" || echo "✗ hexdump"
	@command -v sed >/dev/null 2>&1 && echo "✓ sed" || echo "✗ sed"
	@command -v unzip >/dev/null 2>&1 && echo "✓ unzip" || echo "✗ unzip"
	@command -v python3 >/dev/null 2>&1 && echo "✓ python3" || echo "✗ python3"
	@test -f ./tools/cdi4dc && echo "✓ cdi4dc" || echo "✗ cdi4dc (not found in tools/)"
	@test -f ./tools/cdirip && echo "✓ cdirip" || echo "✗ cdirip (not found in tools/)"