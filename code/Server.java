import java.net.*;
import java.io.*;

public class Server
{
    public Short[] getImage(int port) throws java.io.IOException
    {
        System.out.println("Listening on port...");
        ServerSocket server = new ServerSocket(port);

        Socket client = server.accept();
        System.out.println("Connected...");
        
        InputStream in = client.getInputStream();
        
        byte[] result = new byte[4];

        in.read(result, 0, 4);
        
        
        short w1 = result[0]>0?result[0]:(short)( (~(int)(-result[0]-1))&0xff );
        short w2 = result[1]>0?result[1]:(short)( (~(int)(-result[1]-1))&0xff );
        short h1 = result[2]>0?result[2]:(short)( (~(int)(-result[2]-1))&0xff );
        short h2 = result[3]>0?result[3]:(short)( (~(int)(-result[3]-1))&0xff );
        
        short w = (short)(w1+(w2<<8));
        short h = (short)(h1+(h2<<8));
        
        System.out.println(w);
        System.out.println(h);
        
        Short[] Result = new Short[w*h+2];

        Result[0] = w;
        Result[1] = h;
        
        int count = 0;
        while (count<w*h) {
            Result[count + 2] = (short)in.read();
            count++;
        }
        
        
        in.close();
        client.close();
        server.close();
        
        return Result; 
    }
}
