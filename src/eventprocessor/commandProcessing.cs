using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Azure.Messaging.EventHubs;
using Microsoft.Extensions.Logging;
using Dapr.AzureFunctions.Extension;

namespace Eventing
{
    public static class CommandProcessing
    {
        [FunctionName("CommandProcessing")]
        public static async Task Run(    
            [EventHubTrigger( "requests", ConsumerGroup =  "functions-client", Connection = "EVENTHUB_CONNECTION")]  EventData[] events,
            [DaprState("statestore", Key = "sample")] IAsyncCollector<string> state,
            ILogger log)
        {
            foreach (EventData eventData in events)
            {
                log.LogInformation($"C# Event Hub trigger function processed a message: {eventData.EventBody}");
                await state.AddAsync(eventData.EventBody.ToString());
            }
        }
    }
}