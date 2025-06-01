run-dst:
	@echo "Running tests..."
	./dc-card-maker.sh ./listgames.txt ./src_dir ./dst_dir
	
run-delete:
	sudo rm -rf /media/daoliangshu/911E-9389/

run-sd:
	@echo "Running SD card tests..."
	./dc-card-maker.sh ./listgames.txt ./src_dir /media/daoliangshu/911E-9389/