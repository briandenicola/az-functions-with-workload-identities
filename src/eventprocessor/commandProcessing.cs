using Microsoft.Azure.WebJobs;
using Azure.Messaging.EventHubs;
using Microsoft.Extensions.Logging;

namespace Eventing
{
    public static class CommandProcessing
    {
        [FunctionName("CommandProcessing")]
        public static void Run(    
            [EventHubTrigger( "requests", ConsumerGroup =  "functions-client", Connection = "EVENTHUB_CONNECTION")]  EventData[] events,
            ILogger log)
        {
            foreach (EventData eventData in events)
            {
                log.LogInformation($"C# Event Hub trigger function processed a message: {eventData.EventBody}");
            }
        }
    }
}