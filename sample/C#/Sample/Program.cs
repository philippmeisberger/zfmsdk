using System;
using ZfmSdk;

namespace Sample
{
    class Program
    {
        static void Main(string[] args)
        {
            Zfm.Initialize();
            Zfm.Connect("COM3");
            Console.WriteLine(string.Format("{0} template(s) stored on sensor", Zfm.TemplateNum()));

            if (Zfm.GenImg())
            {
                Zfm.Image2Tz(ZfmCharBuffer.CharBuffer1);
                short index;
                ushort accuracy;
                Zfm.Search(ZfmCharBuffer.CharBuffer1, out index, out accuracy);

                if (index != -1)
                {
                    Console.WriteLine(string.Format("Found template at {0} with accuracy {1}", index, accuracy));
                }
                else
                {
                    Console.WriteLine("Template not found!");
                }
            }
            else
            {
                Console.WriteLine("No finger on sensor!");
            }
            Zfm.UnInitialize();
            Console.ReadLine();
        }
    }
}
