declare module "busboy" {
    import { IncomingHttpHeaders } from "http";
  
    interface BusboyConfig {
      headers: IncomingHttpHeaders;
    }
  
    class Busboy {
      constructor(config: BusboyConfig);
      on(event: string, callback: (...args: any[]) => void): void;
      end(data?: any): void;
    }
  
    export = Busboy;
  }
  