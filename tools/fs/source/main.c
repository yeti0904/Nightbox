// Nightbox FS tool
// Written by yeti0904, starting 19th of November 2023

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#define MAGIC_NUMBER 0x424E

typedef struct {
	uint16_t magicNumber;
	uint16_t numSectors;
	char     diskName[16];
} BootRecord;

void WriteShort(FILE* file, uint16_t v) {
	uint8_t tmp = (uint8_t) (v & 0xFF);
	fwrite(&tmp, 1, 1, file);
	tmp = (uint8_t) ((v & 0xFF00) >> 8);
	fwrite(&tmp, 1, 1, file);
}

uint16_t ReadShort(FILE* file) {
	uint8_t  tmp;
	uint16_t ret;

	fread(&tmp, 1, 1, file);
	ret = tmp;
	fread(&tmp, 1, 1, file);
	ret |= ((uint16_t) tmp) << 8;

	return ret;
}

bool FileExists(const char* path) {
	FILE* file = fopen(path, "r");

	if (file) {
		fclose(file);
		return true;
	}

	return false;
}

bool IsFS(FILE* file) {
	fseek(file, 4, SEEK_SET);

	uint16_t magicNumber = ReadShort(file);
	return magicNumber == MAGIC_NUMBER;
}

void ValidateDisk(FILE* file) {
	fseek(file, 0, SEEK_END);
	size_t size = ftell(file);
	fseek(file, 0, SEEK_SET);

	if (size % 512 != 0) {
		fprintf(stderr, "Invalid disk (size is not a multiple of 512)\n");
		fclose(file);
		exit(1);
	}
}

void WriteBootRecord(FILE* file, BootRecord br) {
	fseek(file, 4, SEEK_SET);

	WriteShort(file, br.magicNumber);
	WriteShort(file, br.numSectors);
	fwrite(br.diskName, 16, 1, file);
}

const char* usage =
	"Usage:\n"
	"    %s {OPERATION} {FILE} [FLAGS]\n"
	"Operations:\n"
	"    makefs {FILE} {DISK NAME}\n"
	"        Creates a NightboxFS filesystem in the given file\n"
	"    info {FILE}\n"
	"        Shows information about the given disk\n";
	

int main(int argc, char** argv) {
	if (argc < 3) {
		printf(usage, argv[0]);
		return 0;
	}

	char* op   = argv[1];
	char* path = argv[2];

	if (!FileExists(path)) {
		fprintf(stderr, "File %s doesn't exist\n", path);
		return 1;
	}

	if (strcmp(op, "makefs") == 0) {
		BootRecord br = {
			.magicNumber = MAGIC_NUMBER
		};

		if (argc != 4) {
			fprintf(stderr, "makefs requires 2 parameters\n");
			return 1;
		}

		FILE* file = fopen(path, "rb+");

		if (!file) {
			perror("Failed to open disk");
			return 1;
		}
		
		ValidateDisk(file);

		fseek(file, 0, SEEK_END);
		size_t size = ftell(file);
		fseek(file, 0, SEEK_SET);

		br.numSectors = (uint16_t) (size / 512);

		if (strlen(argv[3]) > 16) {
			fprintf(stderr, "disk name can't be longer than 16 characters\n");
			return 1;
		}

		memset(br.diskName, 0, 16);
		strcpy(br.diskName, argv[3]);

		WriteBootRecord(file, br);
		printf("Created filesystem in %s\n", path);
	}
	else if (strcmp(op, "info") == 0) {
		FILE* file = fopen(path, "rb");

		if (!file) {
			perror("Failed to open disk");
			return 1;
		}

		ValidateDisk(file);
		
		if (!IsFS(file)) {
			printf("Disk does not contain a Nightbox filesystem\n");
			return 0;
		}

		printf("Disk contains a Nightbox filesystem\n");

		// read name
		char diskName[16];
		fseek(file, 8, SEEK_SET);
		fread(diskName, 16, 1, file);
		printf("    Disk name: %s\n", diskName);
	}
	else {
		fprintf(stderr, "Unknown operation %s\n", op);
		return 1;
	}

	return 0;
}
