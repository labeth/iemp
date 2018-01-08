//File include zone
#include <nokia_3310_lcd.h>
//Pins define
#define encoderPinA 3
#define encoderPinB 4
#define button 2

#define SDA 18
#define SCL 19
#define FSYNC 17
#define AMP A2
#define BIAS A1
Nokia_3310_lcd lcd=Nokia_3310_lcd();
/*---------------------------
Flag zone
---------------------------*/
#define Left 1
#define Right 2
#define PressDown 3
#define Null 0
unsigned char buttonPress;
unsigned char encoderPress;
unsigned char buttonJitter;

/*---------------------------
DDS operation zone
---------------------------*/
#define SINE 1
#define TRIANGLE 2
#define SQUARE 3

#define DDS_Output_Off 0x0100
#define DDS_Output_On  0x0000

unsigned char Wave_Type = SINE;
char Freq_Num[7] = {0,0,1,0,0,0,0};
long frq = 0;

char Vpp_Index = 0;
char Bias_Index = 0;
long Vpp_Result = 0;
long Bias_Result = 0;

void setup()
{
  attachInterrupt(0, buttonP, FALLING);
  attachInterrupt(1, decoderP, FALLING);
  lcd.LCD_3310_init();
  lcd.LCD_3310_clear();
  pinMode (encoderPinA,INPUT);
  pinMode (encoderPinB,INPUT);
  pinMode (button,INPUT);
  pinMode (SDA,OUTPUT);
  pinMode (SCL,OUTPUT);
  pinMode (FSYNC,OUTPUT);
  Write_DDS(DDS_Output_Off);
  
  //Serial.begin(9600);
}

void loop()
{
	Top_Menu();
}
//KeyScan operation function
void buttonP(void)
{
	buttonPress =1;
}

void decoderP(void)
{
	encoderPress=1;
}

unsigned char KeyScan()
{
	if(encoderPress == 1)
	{
		encoderPress = 0;
		if(digitalRead(encoderPinA))
		{}
		else if(digitalRead(encoderPinB))
		{
			return (Left);
		}
		else
		{
			return (Right);
		}
	}
	
	if(buttonPress == 1)
	{
		if(digitalRead(button))
			buttonPress = 0;
		else
		{
			buttonJitter++;
			if(buttonJitter > 50)
			{
				buttonJitter = 0;
				buttonPress = 0;
				return (PressDown);
			}
		}
	}
	
	return (Null);
}

void Top_Menu()
{
	unsigned char Action = Null;
	unsigned char Focus_Index = 1;
	unsigned char Dis_Updata = 1;
	while(1)
	{
		Write_DDS(DDS_Output_Off);
		Action = KeyScan();
		if(Action == Left)
		{
			Action = Null;
			Dis_Updata = 1;
			Focus_Index--;
			if(Focus_Index == 0)
				Focus_Index = 2;
		}
		else if(Action == Right)
		{
			Action = Null;
			Dis_Updata = 1;
			Focus_Index++;
			if(Focus_Index == 3)
				Focus_Index = 1;
		}
		else if(Action == PressDown)
		{
			Action = Null;
			if(Focus_Index == 1)
			{
				Single_Freq();
				lcd.LCD_3310_clear();
				Dis_Updata = 1;
			}
			else if(Focus_Index == 2)
			{
				About_Me();
				lcd.LCD_3310_clear();
				Dis_Updata = 1;
			}
			
		}
		if(Dis_Updata == 1)
		{
			lcd.LCD_3310_write_string(3,0,"IEMP 1.0",0);
			lcd.LCD_3310_write_string(2,2,"Single Freq",(Focus_Index==1)?1:0);
			lcd.LCD_3310_write_string(3,5,"About me",(Focus_Index==2)?1:0);
			Dis_Updata = 0;
		}
	}
}

void About_Me()
{
	unsigned char Action = Null;
	lcd.LCD_3310_clear();
	lcd.LCD_3310_write_string(3,0,"IEMP 1.0",0);
	lcd.LCD_3310_write_string(3,2,"HW V1.0b",0);
	lcd.LCD_3310_write_string(3,3,"SW V1.0b",0);
	lcd.LCD_3310_write_string(0,5,"ITead Studio",0);
	while(Action != PressDown)
		Action = KeyScan();
}
void Single_Freq()
{
	unsigned char Action = Null;
	unsigned char Focus_Index = 1;
	unsigned char Dis_Updata = 1;
	lcd.LCD_3310_clear();
	lcd.LCD_3310_write_string(0,0,"Wave:",(Focus_Index==1)?1:0);
	lcd.LCD_3310_write_string(6,0,"Sine",0);
	lcd.LCD_3310_write_string(0,1,"Frequency:",(Focus_Index==2)?1:0);
	lcd.LCD_3310_write_string(2,2,"0,010,000",0);
	lcd.LCD_3310_write_string(12,2,"Hz",0);
	lcd.LCD_3310_write_string(0,3,"Vpp:",0);
	lcd.LCD_3310_write_string(0,4,"Bias:",0);
	lcd.LCD_3310_write_string(0,5,"Exit",(Focus_Index==3)?1:0);
	
	while(1)
	{
		Action = KeyScan();
		if(Action == Left)
		{
			Action = Null;
			Dis_Updata = 1;
			Focus_Index--;
			if(Focus_Index == 0)
				Focus_Index = 3;
		}
		else if(Action == Right)
		{
			Action = Null;
			Dis_Updata = 1;
			Focus_Index++;
			if(Focus_Index == 4)
				Focus_Index = 1;
		}
		else if(Action == PressDown)
		{
			Action = Null;
			if(Focus_Index == 1)
			{
				Set_Wave();
				Dis_Updata = 1;
			}
			else if(Focus_Index == 2)
			{
				Set_Freq();
				Dis_Updata = 1;
			}
			else if(Focus_Index == 3)
			{
				Write_DDS(DDS_Output_Off);
				return;
			}
			
		}
		Dis_Amp();
		Dis_Bias();
		if(Dis_Updata == 1);
		{
			lcd.LCD_3310_write_string(0,0,"Wave:",(Focus_Index==1)?1:0);
			//lcd.LCD_3310_write_string(6,0,"Sine",0);
			lcd.LCD_3310_write_string(0,1,"Frequency:",(Focus_Index==2)?1:0);
			//lcd.LCD_3310_write_string(2,2,"0,000,100",0);
			//lcd.LCD_3310_write_string(14,2,"Hz",0);
			//lcd.LCD_3310_write_string(0,3,"Amp:",0);
			//lcd.LCD_3310_write_string(0,4,"Bias:",0);
			lcd.LCD_3310_write_string(0,5,"Exit",(Focus_Index==3)?1:0);
		}
	}
}

void Set_Freq()
{
	unsigned char Action = Null;
	unsigned char Focus_Index = 1;
	lcd.LCD_3310_write_string(0,1,"Frequency:",0);
	lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,1);
	while(1)
	{
		Action = KeyScan();
		if(Action == Left)
		{
			Action = Null;
			Focus_Index--;
			if(Focus_Index == 0)
				Focus_Index = 8;
			lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,(Focus_Index == 1)?1:0);
			lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,(Focus_Index == 2)?1:0);
			lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,(Focus_Index == 3)?1:0);
			lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,(Focus_Index == 4)?1:0);
			lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,(Focus_Index == 5)?1:0);
			lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,(Focus_Index == 6)?1:0);
			lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,(Focus_Index == 7)?1:0);
			lcd.LCD_3310_write_string(12,2,"Hz",(Focus_Index == 8)?1:0);
		}
		else if(Action == Right)
		{
			Action = Null;
			Focus_Index++;
			if(Focus_Index == 9)
				Focus_Index = 1;
			lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,(Focus_Index == 1)?1:0);
			lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,(Focus_Index == 2)?1:0);
			lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,(Focus_Index == 3)?1:0);
			lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,(Focus_Index == 4)?1:0);
			lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,(Focus_Index == 5)?1:0);
			lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,(Focus_Index == 6)?1:0);
			lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,(Focus_Index == 7)?1:0);
			lcd.LCD_3310_write_string(12,2,"Hz",(Focus_Index == 8)?1:0);
		}
		else if(Action == PressDown)
		{
			Action = Null;
			if(Focus_Index == 8)
			{
				lcd.LCD_3310_write_string(12,2,"Hz",0);
				return;
			}
			else
			{
				Set_Num(Focus_Index);
				
			}
		}
		Dis_Amp();
		Dis_Bias();
	}
}

void Set_Num(unsigned char Index)
{
	unsigned char Action = Null;
	//long temp = 0;
	while(1)
	{
		Action = KeyScan();
		if(Action == Left)
		{
			Action = Null;
			
			Freq_Num[Index-1]--;
			
			if(Freq_Num[Index-1] < 0)
				Freq_Num[Index-1] = 0;
			
			frq =  (long)Freq_Num[0]*1000000 +
					(long)Freq_Num[1]*100000 +
					(long)Freq_Num[2]*10000 +
					(long)Freq_Num[3]*1000 +
					(long)Freq_Num[4]*100 +
					(long)Freq_Num[5]*10 +
					(long)Freq_Num[6];
			
			if(frq < 100)
			{
				Freq_Num[0] = 0;
				Freq_Num[1] = 0;
				Freq_Num[2] = 0;
				Freq_Num[3] = 0;
				Freq_Num[4] = 1;
				Freq_Num[5] = 0;
				Freq_Num[6] = 0;
			}
			
			frq =  (long)Freq_Num[0]*1000000 +
					(long)Freq_Num[1]*100000 +
					(long)Freq_Num[2]*10000 +
					(long)Freq_Num[3]*1000 +
					(long)Freq_Num[4]*100 +
					(long)Freq_Num[5]*10 +
					(long)Freq_Num[6];
					
			lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,(Index == 1)?1:0);
			lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,(Index == 2)?1:0);
			lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,(Index == 3)?1:0);
			lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,(Index == 4)?1:0);
			lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,(Index == 5)?1:0);
			lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,(Index == 6)?1:0);
			lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,(Index == 7)?1:0);
			
			//Serial.print(temp, DEC);		
			//Serial.print("\n");
			if(Wave_Type == SQUARE)
				Set_DDS(Wave_Type,frq*2);
			else
				Set_DDS(Wave_Type,frq);
		}
		else if(Action == Right)
		{
			Action = Null;
			
			Freq_Num[Index-1]++;
			if(Freq_Num[Index-1] > 9)
				Freq_Num[Index-1] = 9;
			
			frq =  (long)Freq_Num[0]*1000000 +
					(long)Freq_Num[1]*100000 +
					(long)Freq_Num[2]*10000 +
					(long)Freq_Num[3]*1000 +
					(long)Freq_Num[4]*100 +
					(long)Freq_Num[5]*10 +
					(long)Freq_Num[6];
			if((Wave_Type == SINE) && frq > 5000000)
			{
				Freq_Num[0] = 5;
				Freq_Num[1] = 0;
				Freq_Num[2] = 0;
				Freq_Num[3] = 0;
				Freq_Num[4] = 0;
				Freq_Num[5] = 0;
				Freq_Num[6] = 0;
			}
			else if(((Wave_Type == TRIANGLE) || (Wave_Type == SQUARE)) && frq > 1000000)
			{
				Freq_Num[0] = 1;
				Freq_Num[1] = 0;
				Freq_Num[2] = 0;
				Freq_Num[3] = 0;
				Freq_Num[4] = 0;
				Freq_Num[5] = 0;
				Freq_Num[6] = 0;
			}
			
				frq =  (long)Freq_Num[0]*1000000 +
						(long)Freq_Num[1]*100000 +
						(long)Freq_Num[2]*10000 +
						(long)Freq_Num[3]*1000 +
						(long)Freq_Num[4]*100 +
						(long)Freq_Num[5]*10 +
						(long)Freq_Num[6];
			
			lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,(Index == 1)?1:0);
			lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,(Index == 2)?1:0);
			lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,(Index == 3)?1:0);
			lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,(Index == 4)?1:0);
			lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,(Index == 5)?1:0);
			lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,(Index == 6)?1:0);
			lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,(Index == 7)?1:0);
			//Serial.print(temp, DEC);
			//Serial.print("\n");
			
			if(Wave_Type == SQUARE)
				Set_DDS(Wave_Type,frq*2);
			else
				Set_DDS(Wave_Type,frq);
		}
		else if(Action == PressDown)
		{
			Action = Null;
			return;
		}
		Dis_Amp();
		Dis_Bias();
	}
}
void Set_Wave()
{
	unsigned char Action = Null;
	unsigned char Focus_Index = 1;
	//long temp = 0;
	lcd.LCD_3310_write_string(0,0,"Wave:",0);
	if(Wave_Type == SINE)
	{
		lcd.LCD_3310_write_string(6,0,"Sine",1);
		Focus_Index = 1;
	}
	else if(Wave_Type == TRIANGLE)
	{
		lcd.LCD_3310_write_string(6,0,"Triangle",1);
		Focus_Index = 2;
	}
	else if(Wave_Type == SQUARE)
	{
		lcd.LCD_3310_write_string(6,0,"SQUARE",1);
		Focus_Index = 3;
	}
	while(1)
	{
		Action = KeyScan();
		if(Action == Left)
		{
			Action = Null;
			Focus_Index--;
			if(Focus_Index == 0)
				Focus_Index = 3;
			lcd.LCD_3310_write_string(6,0,"        ",0);
			
			if(Focus_Index == 1)
			{	
				lcd.LCD_3310_write_string(6,0,"Sine",1);
				frq =  (long)Freq_Num[0]*1000000 +
						(long)Freq_Num[1]*100000 +
						(long)Freq_Num[2]*10000 +
						(long)Freq_Num[3]*1000 +
						(long)Freq_Num[4]*100 +
						(long)Freq_Num[5]*10 +
						(long)Freq_Num[6];
				if(frq > 5000000)
				{
					Freq_Num[0] = 5;
					Freq_Num[1] = 0;
					Freq_Num[2] = 0;
					Freq_Num[3] = 0;
					Freq_Num[4] = 0;
					Freq_Num[5] = 0;
					Freq_Num[6] = 0;
				}	
					lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,0);
					lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,0);
					lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,0);
					lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,0);
					lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,0);
					lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,0);
					lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,0);
				
				
				Wave_Type = SINE;
				Set_DDS(Wave_Type,frq);
			}
			else if(Focus_Index == 2)
			{
				lcd.LCD_3310_write_string(6,0,"Triangle",1);
				frq =  (long)Freq_Num[0]*1000000 +
						(long)Freq_Num[1]*100000 +
						(long)Freq_Num[2]*10000 +
						(long)Freq_Num[3]*1000 +
						(long)Freq_Num[4]*100 +
						(long)Freq_Num[5]*10 +
						(long)Freq_Num[6];
				if(frq > 1000000)
				{
					Freq_Num[0] = 1;
					Freq_Num[1] = 0;
					Freq_Num[2] = 0;
					Freq_Num[3] = 0;
					Freq_Num[4] = 0;
					Freq_Num[5] = 0;
					Freq_Num[6] = 0;
				}	
					lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,0);
					lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,0);
					lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,0);
					lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,0);
					lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,0);
					lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,0);
					lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,0);
				
				Wave_Type = TRIANGLE;
				Set_DDS(Wave_Type,frq);
			}
			else if(Focus_Index == 3)
			{
				lcd.LCD_3310_write_string(6,0,"SQUARE",1);
				frq =  (long)Freq_Num[0]*1000000 +
						(long)Freq_Num[1]*100000 +
						(long)Freq_Num[2]*10000 +
						(long)Freq_Num[3]*1000 +
						(long)Freq_Num[4]*100 +
						(long)Freq_Num[5]*10 +
						(long)Freq_Num[6];
				if(frq > 1000000)
				{
					Freq_Num[0] = 1;
					Freq_Num[1] = 0;
					Freq_Num[2] = 0;
					Freq_Num[3] = 0;
					Freq_Num[4] = 0;
					Freq_Num[5] = 0;
					Freq_Num[6] = 0;
				}	
					lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,0);
					lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,0);
					lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,0);
					lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,0);
					lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,0);
					lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,0);
					lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,0);
				
				Wave_Type = SQUARE;
				Set_DDS(Wave_Type,frq*2);
			}
		}
		else if(Action == Right)
		{
			Action = Null;
			Focus_Index++;
			if(Focus_Index == 4)
				Focus_Index = 1;
			lcd.LCD_3310_write_string(6,0,"        ",0);
			if(Focus_Index == 1)
			{	
				lcd.LCD_3310_write_string(6,0,"Sine",1);
				frq =  (long)Freq_Num[0]*1000000 +
						(long)Freq_Num[1]*100000 +
						(long)Freq_Num[2]*10000 +
						(long)Freq_Num[3]*1000 +
						(long)Freq_Num[4]*100 +
						(long)Freq_Num[5]*10 +
						(long)Freq_Num[6];
				if(frq > 5000000)
				{
					Freq_Num[0] = 5;
					Freq_Num[1] = 0;
					Freq_Num[2] = 0;
					Freq_Num[3] = 0;
					Freq_Num[4] = 0;
					Freq_Num[5] = 0;
					Freq_Num[6] = 0;
					
					lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,0);
					lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,0);
					lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,0);
					lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,0);
					lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,0);
					lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,0);
					lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,0);
				}
				
				Wave_Type = SINE;
				Set_DDS(Wave_Type,frq);
			}
			else if(Focus_Index == 2)
			{
				lcd.LCD_3310_write_string(6,0,"Triangle",1);
				frq =  (long)Freq_Num[0]*1000000 +
						(long)Freq_Num[1]*100000 +
						(long)Freq_Num[2]*10000 +
						(long)Freq_Num[3]*1000 +
						(long)Freq_Num[4]*100 +
						(long)Freq_Num[5]*10 +
						(long)Freq_Num[6];
				if(frq > 1000000)
				{
					Freq_Num[0] = 1;
					Freq_Num[1] = 0;
					Freq_Num[2] = 0;
					Freq_Num[3] = 0;
					Freq_Num[4] = 0;
					Freq_Num[5] = 0;
					Freq_Num[6] = 0;
					
					lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,0);
					lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,0);
					lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,0);
					lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,0);
					lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,0);
					lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,0);
					lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,0);
				}
				Wave_Type = TRIANGLE;
				Set_DDS(Wave_Type,frq);
			}
			else if(Focus_Index == 3)
			{
				lcd.LCD_3310_write_string(6,0,"SUQARE",1);
				frq =  (long)Freq_Num[0]*1000000 +
						(long)Freq_Num[1]*100000 +
						(long)Freq_Num[2]*10000 +
						(long)Freq_Num[3]*1000 +
						(long)Freq_Num[4]*100 +
						(long)Freq_Num[5]*10 +
						(long)Freq_Num[6];
				if(frq > 1000000)
				{
					Freq_Num[0] = 1;
					Freq_Num[1] = 0;
					Freq_Num[2] = 0;
					Freq_Num[3] = 0;
					Freq_Num[4] = 0;
					Freq_Num[5] = 0;
					Freq_Num[6] = 0;
					
					lcd.LCD_3310_write_char_point(2,2,Freq_Num[0]+48,0);
					lcd.LCD_3310_write_char_point(4,2,Freq_Num[1]+48,0);
					lcd.LCD_3310_write_char_point(5,2,Freq_Num[2]+48,0);
					lcd.LCD_3310_write_char_point(6,2,Freq_Num[3]+48,0);
					lcd.LCD_3310_write_char_point(8,2,Freq_Num[4]+48,0);
					lcd.LCD_3310_write_char_point(9,2,Freq_Num[5]+48,0);
					lcd.LCD_3310_write_char_point(10,2,Freq_Num[6]+48,0);
				}
				Wave_Type = SQUARE;
				Set_DDS(Wave_Type,frq*2);
			}
		}
		else if(Action == PressDown)
		{
			Action = Null;
			if(Focus_Index == 1)
			{
				lcd.LCD_3310_write_string(6,0,"        ",0);
				lcd.LCD_3310_write_string(6,0,"Sine",0);
				return;
			}
			else if(Focus_Index == 2)
			{
				lcd.LCD_3310_write_string(6,0,"        ",0);
				lcd.LCD_3310_write_string(6,0,"Triangle",0);
				return;
			}
			else if(Focus_Index == 3)
			{
				lcd.LCD_3310_write_string(6,0,"        ",0);
				lcd.LCD_3310_write_string(6,0,"SQUARE",0);
				return;
			}
		}
	
	Dis_Amp();
	Dis_Bias();
	}
	
}
/*
void Dis_Amp()
{
	long Vpp_Result = 0;
	unsigned char i = 0;
	for(i = 0;i<16;i++)
	{
		Vpp_Result = Vpp_Result + analogRead(A2);
	}
	Vpp_Result = Vpp_Result / 16;
	Vpp_Result = (long)((float)Vpp_Result * 3300 / 1024);
	
	if((frq<5000001)&&(frq>4000000))
		Vpp_Result = (long)((float)Vpp_Result * 3);
	
	else if ((frq<4000001)&&(frq>3000000))
		Vpp_Result = (float)Vpp_Result * 3;
	else if ((frq<3000001)&&(frq>2000000))
		Vpp_Result = (float)Vpp_Result * 3;
	else if ((frq<2000001)&&(frq>1000000))
		Vpp_Result = (float)Vpp_Result * 3;
	else
		Vpp_Result = (float)Vpp_Result * 3.14;
	
	Vpp_Result = Vpp_Result/100;
	Vpp_Result = Vpp_Result*100;
	lcd.LCD_3310_write_string(6,3,"     ",0);
	lcd.LCD_3310_write_num(6,3,Vpp_Result,0);
	lcd.LCD_3310_write_string(12,3,"mV",0);
	
	
}
void Dis_Bias()
{
	long Bias_Result = 0;
	unsigned char i = 0;
	for(i = 0;i<16;i++)
	{
		Bias_Result = Bias_Result + analogRead(A1);
	}
	Bias_Result = Bias_Result / 16;
	Bias_Result = (long)((float)Bias_Result * 3300 / 1024);
	Bias_Result = (Bias_Result-2007) * 13;
	if(Bias_Result > 5000) Bias_Result = 5000;
	if(Bias_Result < -5000) Bias_Result = -5000;
	Bias_Result = Bias_Result/100;
	Bias_Result = Bias_Result*100;
	lcd.LCD_3310_write_string(6,4,"     ",0);
	lcd.LCD_3310_write_num(6,4,Bias_Result,0);
	lcd.LCD_3310_write_string(12,4,"mV",0);
}
*/

void Dis_Amp()
{
	if(Vpp_Index == 32)
	{
	
		Vpp_Index = 0;
		Vpp_Result = Vpp_Result / 32;
		Vpp_Result = (long)((float)Vpp_Result * 3300 / 1024);
	
		if((frq<5000001)&&(frq>4000000))
			Vpp_Result = (long)((float)Vpp_Result * 3);
	
		else if ((frq<4000001)&&(frq>3000000))
			Vpp_Result = (float)Vpp_Result * 3;
		else if ((frq<3000001)&&(frq>2000000))
			Vpp_Result = (float)Vpp_Result * 3;
		else if ((frq<2000001)&&(frq>1000000))
			Vpp_Result = (float)Vpp_Result * 3;
		else
			Vpp_Result = (float)Vpp_Result * 3.14;
	
		Vpp_Result = Vpp_Result/100;
		Vpp_Result = Vpp_Result*100;
		lcd.LCD_3310_write_string(6,3,"     ",0);
		lcd.LCD_3310_write_num(6,3,Vpp_Result,0);
		lcd.LCD_3310_write_string(12,3,"mV",0);
		Vpp_Result = 0;
	}
	else
	{
	
		Vpp_Result = Vpp_Result + analogRead(A2);
		Vpp_Index++;
	}
	
	
}
void Dis_Bias()
{
	
	if(Bias_Index == 32)
	{
		
		Bias_Index = 0;
		Bias_Result = Bias_Result / 32;
		Bias_Result = (long)((float)Bias_Result * 3300 / 1024);
		Bias_Result = (Bias_Result-2007) * 13;
		if(Bias_Result > 5000) Bias_Result = 5000;
		if(Bias_Result < -5000) Bias_Result = -5000;
		Bias_Result = Bias_Result/100;
		Bias_Result = Bias_Result*100;
		lcd.LCD_3310_write_string(6,4,"     ",0);
		lcd.LCD_3310_write_num(6,4,Bias_Result,0);
		lcd.LCD_3310_write_string(12,4,"mV",0);
		Bias_Result = 0;
	}
	else
	{
		Bias_Result = Bias_Result + analogRead(A1);
		Bias_Index++;
	}	
}
void Write_DDS(unsigned int Command)
{
  unsigned char index = 0;
  
  digitalWrite(FSYNC,LOW);
  
  for(index = 0;index < 16;index++)
  {
    if(Command & 0x8000)
      digitalWrite(SDA,HIGH);
    else 
      digitalWrite(SDA,LOW);
    
    Command = Command << 1;
    
    digitalWrite(SCL,LOW);
    digitalWrite(SCL,HIGH);
  }
  
  digitalWrite(FSYNC,HIGH);
}
void Set_DDS(unsigned char type,unsigned long frequency)
{
  unsigned int Send_Buf = 0;
  unsigned long temp = 0;
  switch (type)
  {
    case SINE:
      Write_DDS(0x2000);
      break;
    case TRIANGLE:
      Write_DDS(0x2002);
      break;
    case SQUARE:
      Write_DDS(0x2020);
      break;
    default:
      Write_DDS(DDS_Output_Off);
  }
  temp = (unsigned long)((float)frequency * 268435456 / 25000559);
  //temp = (unsigned long)((float)frequency * 268435456 / 30000000);
  Send_Buf = (temp & 0x7fff) | 0x4000;
  Write_DDS(Send_Buf);
  temp = temp >> 14;
  Send_Buf = (temp & 0x7fff) | 0x4000;
  Write_DDS(Send_Buf);
  
}
