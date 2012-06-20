
#define dbStatus(note, err) \
if(err) {\
printf ("%s:0x%lX,%ld,%s @ %s: %d\n",note, err, err, (char*)&err,__FILE__, __LINE__);\
fflush(stdout);\
}

#define checkStatus( err) \
if(err) {\
printf ("Error:0x%lX,%ld,%s @ %s: %d\n",err, err, (char*)&err,__FILE__, __LINE__);\
fflush(stdout);\
return err; \
}
//printf("Error: %s ->  %s: %d\n", (char *)&err,__FILE__, __LINE__);

#define THROW_RESULT(str) 										\
if (result) {												\
printf ("Error:%s=0x%lX,%ld,%s\n\n",		 			\
str,result, result, (char*)&result);	\
throw result;											\
}

#define XThrowIfError(error, operation)										\
do {																	\
OSStatus __err = error;												\
if (__err) {														\
printf ("Error:%s=0x%lX,%ld,%s\n\n",	 						\
operation,__err, __err, (char*)&__err);							\
throw __err;													\
}																	\
} while (0)

#define XWarnIfError(error, operation)										\
do {																	\
OSStatus __err = error;												\
if (__err) {														\
printf ("Error:%s=0x%lX,%ld,%s\n\n",	 						\
operation,__err, __err, (char*)&__err);							\
}																	\
} while (0)

