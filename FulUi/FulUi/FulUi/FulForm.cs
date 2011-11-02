using System;
using System.IO.Ports;
using System.Text;
using System.Windows.Forms;

namespace FulUi
{
    public partial class FulForm : Form
    {
        private SerialPort serialPort;

        private byte[] buffer = new byte[5];
        
        public FulForm()
        {
            InitializeComponent();
            buffer[0] = 0x13;
            buffer[1] = 0x37;


            var portNames = SerialPort.GetPortNames();

            foreach (var port in portNames)
            {
                System.Diagnostics.Trace.WriteLine(port);
            }
        }

        private void sendSerial()
        {
            if (this.serialPort == null) return;
            if(this.serialPort.IsOpen)
                this.serialPort.Write(buffer, 0, 5);
            else
                System.Diagnostics.Trace.WriteLine("Borken");

                if (this.serialPort.BytesToRead >0)
                {
                    System.Diagnostics.Trace.WriteLine("Haz data!");
                    var buff = new byte[this.serialPort.BytesToRead];
                    int amt = 0;
                    
                    //while((amt = this.serialPort.Read(buff,0,buff.Length)) >0)
                    //{
                    //    System.Diagnostics.Trace.WriteLine(Encoding.Default.GetString(buff,0,amt));
                    //}
                }
        }

        private void btnReconnect_Click(object sender, EventArgs e)
        {
            var comTxt = this.txtCom.Text;
            if(!string.IsNullOrEmpty(comTxt))
            {
                this.serialPort = new SerialPort(comTxt, 57600);
                this.serialPort.Open();
            }
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            buffer[2] = 0x7f;
            buffer[3] = 0x7f;
            buffer[4] = 0x7f;
            this.sendSerial();
        }

        private void btnForward_Click(object sender, EventArgs e)
        {
            buffer[2] = 0xff;
            buffer[3] = 0xff;
            this.sendSerial();
        }

        private void btnBack_Click(object sender, EventArgs e)
        {
            buffer[2] = 0x00;
            buffer[3] = 0x00;
            this.sendSerial();
        }

        private void btnRight_Click(object sender, EventArgs e)
        {
            buffer[2] = 0xff;
            buffer[3] = 0x7f;
            this.sendSerial();
        }

        private void btnLeft_Click(object sender, EventArgs e)
        {
            buffer[2] = 0x7f;
            buffer[3] = 0xff;
            this.sendSerial();
        }

        private void btnUp_Click(object sender, EventArgs e)
        {
            buffer[4] = 0xff;
            this.sendSerial();
        }

        private void btnDown_Click(object sender, EventArgs e)
        {
            buffer[4] = 0x00;
            this.sendSerial();
        }
    }
}
