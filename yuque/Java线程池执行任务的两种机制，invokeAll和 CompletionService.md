# Java�̳߳�ִ����������ֻ��ƣ�invokeAll�� CompletionService

ͨ��Java�̳߳�ִ�е��������������ͣ�һ���ǲ�������ֵ��Runnable�� ��һ���Ǵ�����ֵ��Callable��<br />?<br />���ڲ�������ֵ������ͨ�����ǲ�̫��ע�����Ƿ�ִ�н����Լ�������Ӧ������Щʲô�����ǽ������ύ���̳߳أ� Ȼ����Լ��ɱ�����顣<br />?<br />������ֵ������ִ�н��ͨ���ܵ���ǰ����������������ύ���̳߳غ���Ҫ�ȴ�����ķ��ء��������������ǻ��в�ͬ��������ʱ��ǰ�������������ύ���̳߳ص�����Ľ���� ����ʱ����ֻ����ĳһ�������ִ�н�����ͺñȷ���ķ���Ա��Ҫ�ȴ����������й˿��ò���ϲ�����ʰ����ʳ�õİ���ȴ���Ե���ѧ���ò���϶�����ʰ��<br />?<br />Java�̳߳ضԶ��������������ṩ��ͬ�Ľ������<br />?<br />����������������ִ�н���Ŀ���ֱ��ʹ���̳߳ص�invokeAll����

```java
public class Main {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        List<Callable<Integer>> tasks = new ArrayList<>();
        for( int i = 0; i < 10; i++) {
            tasks.add(()->{
                Random random = new Random();
                int second = random.nextInt(10);
                Thread.sleep(second * 1000) ;
                return second;
            });
        }
        ExecutorService executorService = Executors.newFixedThreadPool(10);
        List<Future<Integer>> futures = executorService.invokeAll(tasks);
        for( int i = 0; i < futures.size(); i++) {
            System.out.println(futures.get(i).get());
        }

        executorService.shutdown();
    }
}
```

���ϳ����嵥�е��̳߳�ִ��10��������Щ������������ʱ�����е����񶼷���tasks�����С�<br />?<br />���ǳ�ʼ��һ������Ϊʱ�Ĺ̶���С���̳߳�ִ����Щ���񣬷���invokeAll���û�����������������ִ����Ϻ󷵻أ�Ȼ������ӡ��Щ���ؽ��������������δ���Ῠ�Ϻܳ�ʱ�䣬����˲�������� ����invokeAll�����ԣ������������ִ����Ϻ�ŷ��ء�<br />?<br />���ڲ��������������ִ�н���������Ե�������ÿ���������ģ�invokeAll���Եò��Ѻ��ˣ���Ȼ���ս��û����ִ��������������Ҫ��ͬ����ʱ�䣬����ִ����һ������ʹ���һ������Ľ�������Եø������Ի�ô��������ض�������ͼƬ���������һ�ž���ʾһ����Ȼ�и��õ��û����飬���������������ǿ���ʹ��CompletionService��<br />?<br />CompletionService��������������ִ�н����˭��ִ����Ϸ���˭�� ���������������е����룬���������������ִ�����ʱ��ִ�еĽ����һ��Future������ά����һ���޽��������У��ⲿ����Ϳ���ͨ��take������ȡ�������������Ϊ�գ�Ҳ���ǻ�û��ִ����ϵ����� ��ôtake�������������ⲿ��������ȴ���

```java
public class Main {
    public static void main(String[] args) throws InterruptedException, ExecutionException {
        List<Callable<Integer>> tasks = new ArrayList<>();
        for( int i = 0; i < 10; i++) {
            tasks.add(()->{
                Random random = new Random();
                int second = random.nextInt(10);
                Thread.sleep(second * 1000) ;
                return second;
            });
        }
        ExecutorService executorService = Executors.newFixedThreadPool(10);

        CompletionService<Integer> completionService = new ExecutorCompletionService(executorService);
        tasks.forEach(task -> completionService.submit(task));

        for( int i = 0; i < tasks.size(); i++) {
            System.out.println(completionService.take().get());
        }

        executorService.shutdown();
    }
}
```

ִ������Ĵ��벻�᳤ʱ�俨�Ϻ�˲������������ƽ���Ĵ�ӡÿ�������ִ�н���� ֪����������ִ����϶��������� 
