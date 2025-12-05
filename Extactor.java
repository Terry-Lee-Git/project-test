import javax.xml.stream.*;
import java.io.InputStream;

public class AppHdrExtractor {

    public static class AppHdrResult {
        public String bizMsgIdr;
        public String msgDefIdr;
        public String bizSvc;

        @Override
        public String toString() {
            return "bizMsgIdr=" + bizMsgIdr +
                   ", msgDefIdr=" + msgDefIdr +
                   ", bizSvc=" + bizSvc;
        }
    }

    public static AppHdrResult extract(InputStream xml) throws Exception {
        XMLInputFactory factory = XMLInputFactory.newInstance();
        factory.setProperty(XMLInputFactory.IS_NAMESPACE_AWARE, true);

        XMLStreamReader r = factory.createXMLStreamReader(xml);
        AppHdrResult result = new AppHdrResult();

        int depth = 0;
        boolean inAppHdr = false;

        while (r.hasNext()) {
            int event = r.next();

            if (event == XMLStreamConstants.START_ELEMENT) {
                String name = r.getLocalName();

                if (!inAppHdr && name.equals("AppHdr")) {
                    inAppHdr = true;
                    depth = 1;
                    continue;
                }

                if (inAppHdr) {
                    depth++;

                    switch (name) {
                        case "BizMsgIdr":
                            result.bizMsgIdr = r.getElementText();
                            depth--;
                            break;
                        case "MsgDefIdr":
                            result.msgDefIdr = r.getElementText();
                            depth--;
                            break;
                        case "BizSvc":
                            result.bizSvc = r.getElementText();
                            depth--;
                            break;
                    }
                }

            } else if (event == XMLStreamConstants.END_ELEMENT) {
                if (inAppHdr) {
                    depth--;
                    if (depth == 0) break; // 完全离开 AppHdr
                }
            }
        }
        return result;
    }
}