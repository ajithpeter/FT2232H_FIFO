#include <stdio.h>
#include <ftd2xx.h>
#include <WinTypes.h>
#include <unistd.h>

#define OneSector 1024

void testFIFO()
{
	FT_HANDLE ftHandle;
	FT_STATUS ftStatus;
	DWORD EventDWord;
	DWORD RxBytes;
	DWORD TxBytes;
	DWORD BytesReceived;
	char rxBuffer[8192];
	int i;

	FILE* fptr;


	UCHAR Mask = 0x00;
	UCHAR Mode;

	fptr = fopen("tempFile", "w");

	ftStatus = FT_Open(0, &ftHandle);
	if(ftStatus != FT_OK)
	{
		// FT_Open failed return;
		printf("FT_Open FAILED! \r\n");
	}
	else
	{
		printf("FT_Open SUCCESS! \r\n");
	}

/*	Mode = 0x00;
	FT_SetBitMode(ftHandle, Mask, Mode);
	sleep(1);
	Mode = 0x40;
	FT_SetBitMode(ftHandle, Mask, Mode);
	FT_SetLatencyTimer(ftHandle, 2);
	FT_Purge(ftHandle, FT_PURGE_RX);
*/
	while (1)
	{
		ftStatus = FT_GetStatus(ftHandle, &RxBytes, &TxBytes, &EventDWord);
		if (ftStatus == FT_OK)
		{
			if (RxBytes >= OneSector)
			{
//				printf("RxBytes: %d\n", RxBytes);
				ftStatus = FT_Read(ftHandle,rxBuffer,RxBytes,&BytesReceived);
				if (ftStatus == FT_OK)
				{
					fwrite(rxBuffer, sizeof(char), BytesReceived, fptr);
					fflush(fptr);
					// FT_Read OK
/*					printf("Read %d Bytes ....\n", BytesReceived);

					for (i = 0; i < BytesReceived; i++)
					{
						printf("0x%x  ", rxBuffer[i]);
					}

					printf ("\n\n\n");
*/
				}
				else
				{
					// FT_Read Failed
					printf("Read Failed....\n");
				}
			}
		}
		else
		{
			printf("Error polling status...\n");
		}
		
	}


}

int main(int argc, char** argv)
{
	testFIFO();
	return 0;
}
