#include "skynet.h"

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <memory.h>

struct mylogger {
	char * filename;
	int isFile;
};

struct mylogger *
mylogger_create(void) {
	struct mylogger * inst = skynet_malloc(sizeof(*inst));
	inst->isFile = 0;
	inst->filename = NULL;
	return inst;
}

void
mylogger_release(struct mylogger * inst) {
	if (inst->isFile) {
		skynet_free(inst->filename);
	}
	skynet_free(inst);
}


static int
_mylogger(struct skynet_context * context, void *ud, int type, int session, uint32_t source, const void * msg, size_t sz) {
	static char fname[256];
	struct mylogger * inst = ud;
	char *filename = inst->filename;
	FILE *handle = NULL;
	time_t t;
	time(&t);
	struct tm *now;
	now = localtime(&t);
	if (inst->isFile == 1)
	{
		sprintf(fname,"%s_%d-%02d-%02d.log", filename, now->tm_year + 1900, now->tm_mon+1, now->tm_mday);
		handle = fopen(fname,"a+");
		//如果有error 字段加外写一份到error文件
		char *err = strstr((char*)msg, "error");
		if(err)
		{
			sprintf(fname,"%s_%d-%02d-%02d.error", filename, now->tm_year + 1900, now->tm_mon+1, now->tm_mday);
			FILE *handle_err = fopen(fname,"a+");
			if (handle_err)
			{
				fprintf(handle_err,"%02d:%02d:%02d ", now->tm_hour,now->tm_min,now->tm_sec);
				fprintf(handle_err, "[%x] ",source);
				fwrite(msg, sz , 1, handle_err);
				fprintf(handle_err, "\n\n");
				fflush(handle_err);
				fclose(handle_err);
			}
		}
	}
	else
		handle = stdout;

	if(handle)
	{
		fprintf(handle,"%02d:%02d:%02d ", now->tm_hour,now->tm_min,now->tm_sec);
		fprintf(handle, "[%x] ",source);
		fwrite(msg, sz , 1, handle);
		fprintf(handle, "\n");
		fflush(handle);
	}
	else
		printf("error logger can't open log file!!\n");
	if (inst->isFile == 1 && handle)
		fclose(handle);

	return 0;
}

int
mylogger_init(struct mylogger * inst, struct skynet_context *ctx, const char * parm) {
	if (parm) {
		inst->isFile = 1;
		inst->filename = skynet_strdup(parm);
	}
	skynet_callback(ctx, inst, _mylogger);
	skynet_command(ctx, "REG", ".logger");
	return 0;
}
