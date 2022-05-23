using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json; 
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;

using Azure.Core;
using Azure.Identity;

using Azure.Messaging.EventHubs;
using Microsoft.Extensions.Logging;


namespace Eventing
{
    public static class CommandProcessing
    {
        [FunctionName("CommandProcessing")]
        public static async Task Run(
        
            [EventHubTrigger(
                "requests",
                ConsumerGroup =  "functions-client",
                Connection = "EVENTHUB_CONNECTION")] string[] events,
            ILogger log)
        {
            foreach ( var message in events )
            {
                log.LogInformation($"C# Event Hub trigger function processed a message: {message}");
            }

        }
    }
}